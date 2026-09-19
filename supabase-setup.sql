-- ============================================
--  건강판다 · 슈퍼베이스 표 만들기
--  Supabase 대시보드 → SQL Editor 에 붙여넣고 Run
--  (여러 번 실행해도 안전합니다)
-- ============================================


-- ============================================
--  1. 주문 표
-- ============================================

create table if not exists public.orders (
  id           bigint generated always as identity primary key,
  created_at   timestamptz not null default now(),
  order_no     text        not null,          -- 주문번호 (예: HP-20260919-4821)
  items        jsonb       not null,          -- 담은 상품 목록
  goods_total  integer     not null,          -- 상품 금액
  ship_fee     integer     not null,          -- 배송비
  total        integer     not null           -- 결제 금액
);

-- 보안 켜기 (이걸 켜야 아래 규칙이 적용됩니다)
alter table public.orders enable row level security;

-- 규칙: 누구나 "주문을 넣는" 것만 가능
--   읽기 규칙은 일부러 만들지 않습니다.
--   → 손님이 다른 사람의 주문을 볼 수 없습니다.
--   → 주문 확인은 대시보드 Table Editor 에서 하세요.
drop policy if exists "anyone can place an order" on public.orders;

create policy "anyone can place an order"
  on public.orders
  for insert
  to anon, authenticated
  with check (true);


-- ============================================
--  2. 상품 표
-- ============================================

create table if not exists public.products (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  sort_order  integer     not null default 0, -- 화면에 보여줄 순서
  name        text        not null unique,    -- 상품 이름
  category    text        not null,           -- 분류
  price       integer     not null,           -- 지금 가격
  old_price   integer     not null,           -- 할인 전 가격
  photo       text        not null,           -- 상품 이미지 경로
  is_best     boolean     not null default false,  -- BEST 배지를 붙일지
  card_style  text                            -- 카드 모양 (shape2 / shape3 / 비움)
);

alter table public.products enable row level security;

-- 규칙: 누구나 "읽기"만 가능
--   → 손님이 상품 정보를 고치거나 지울 수 없습니다.
--   → 상품 추가·수정은 대시보드 Table Editor 에서 하세요.
drop policy if exists "anyone can read products" on public.products;

create policy "anyone can read products"
  on public.products
  for select
  to anon, authenticated
  using (true);


-- ============================================
--  3. 상품 7개 넣기
--     이름이 같으면 새 값으로 덮어씁니다
-- ============================================

insert into public.products
  (sort_order, name, category, price, old_price, photo, is_best, card_style)
values
  (1, '치석 케어 덴탈츄',   '치아 건강',   12900, 19000, 'images/dental.svg',     false, null),
  (2, '편안한 장 유산균',   '장 건강',     16900, 25000, 'images/probiotics.svg', false, null),
  (3, '맑은 눈 루테인',     '눈·피부',     18900, 28000, 'images/lutein.svg',     true,  'shape2'),
  (4, '반짝 피부 오메가3',  '눈·피부',     19900, 29000, 'images/omega3.svg',     false, 'shape3'),
  (5, '튼튼 관절 영양제',   '튼튼 영양제', 21900, 32000, 'images/joint.svg',      true,  null),
  (6, '편안한 밤 진정츄',   '마음 안정',   23900, 34000, 'images/calm.svg',       false, null),
  (7, '튼튼 심장 코엔자임', '튼튼 영양제', 26900, 38000, 'images/heart.svg',      false, null)
on conflict (name) do update set
  sort_order = excluded.sort_order,
  category   = excluded.category,
  price      = excluded.price,
  old_price  = excluded.old_price,
  photo      = excluded.photo,
  is_best    = excluded.is_best,
  card_style = excluded.card_style;


-- ============================================
--  확인용
-- ============================================
-- select * from public.products order by sort_order;
-- select * from public.orders   order by id desc;
